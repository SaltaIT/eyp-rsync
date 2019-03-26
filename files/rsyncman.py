#!/usr/bin/python

import os.path
import getpass
import sys
import logging
import json
import psutil,os
import datetime, time
import socket
import smtplib
import re
import getopt
from ConfigParser import SafeConfigParser
from subprocess import Popen,PIPE,STDOUT
from os import access, R_OK
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

error_count = 0
execute_rsync = True

def help():
    print 'Usage: '+sys.argv[0]+' [-c <config file>] [-b] [-d] [-S]'
    print ''
    print '-h,--help: print this message'
    print '-c,--config: config file'
    print '-b,--syncback: sync from destination to origin'
    print '-d,--dryrun: dry run - just simulate execution'
    print '-S,--canarystring: canary string'
    print ''

def sendReportEmail(to_addr, id_host):
    global error_count
    global logFile

    from_addr=getpass.getuser()+'@'+socket.gethostname()
    if execute_rsync:
        msg = MIMEMultipart()
        msg['From'] = from_addr
        msg['To'] = to_addr
        if error_count > 0:
            msg['Subject'] = id_host+"-RSYNCMAN-ERROR"
        else:
            msg['Subject'] = id_host+"-RSYNCMAN-OK"

        body = "please check "+logFile+" on "+socket.gethostname()
        msg.attach(MIMEText(body, 'plain'))

        server = smtplib.SMTP('localhost')
        text = msg.as_string()
        server.sendmail(from_addr, to_addr, text)
        server.quit()

        logging.info("sent report to "+to_addr)
    else:
        if error_count > 0:
            logging.info("DRY RUN: sending ERROR report to: "+to_addr+" from: "+from_addr)
        else:
            logging.info("DRY RUN: sending OK report to "+to_addr+" from: "+from_addr)

# thank god for stackoverflow - https://stackoverflow.com/questions/25283882/determining-the-filesystem-type-from-a-path-in-python
def get_fs_type(path):
    partition = {}
    for part in psutil.disk_partitions(True):
        partition[part.mountpoint] = (part.fstype, part.device)
    if path in partition:
        return partition[path]
    splitpath = path.split(os.sep)
    for i in xrange(len(splitpath),0,-1):
        path = os.sep.join(splitpath[:i]) + os.sep
        if path in partition:
            return partition[path]
        path = os.sep.join(splitpath[:i])
        if path in partition:
            return partition[path]
    return ("unkown","none")

def get_remote_fs_type(remote, path):
    global error_count

    if not remote:
        return get_fs_type(path)[0]

    #stat -f -c %T .
    command='ssh '+remote+' stat -f -c %T '+path+' 2>/dev/null'
    process = Popen(command,stderr=PIPE,stdout=PIPE,shell=True)
    data = process.communicate()[0]
    if process.wait() != 0:
        # logging.error("ABORTING  - error getting remote fs type")
        # error_count=error_count+1
        return "unkown"
    else:
        return data.splitlines()[0]


def runJob(ionice,delete,exclude,rsyncpath,path,remote,remotepath,checkfile,expected_fs,expected_remote_fs,syncback,canaryfile,canary_string,exclude_from,default_reverse,compress):
    global error_count

    if default_reverse:
        move_data_from_remote= not syncback
    else:
        move_data_from_remote=syncback

    if move_data_from_remote:
        basename_path=os.path.basename(path)
        dirname_path=os.path.dirname(path)
        command=ionice+'rsync -v -a -H -x --numeric-ids '+compress+delete+exclude_from+exclude+rsyncpath+' '+remote+remotepath+'/'+basename_path+' '+dirname_path+' 2>&1'
    else:
        command=ionice+'rsync -v -a -H -x --numeric-ids '+compress+delete+exclude_from+exclude+rsyncpath+' '+path+' '+remote+remotepath+' 2>&1'
    if execute_rsync:
        if canaryfile:
            canaryfh = open(canaryfile,"w+")
            if canary_string:
                canaryfh.write(canary_string+" - ")
            canaryfh.write(datetime.datetime.fromtimestamp(ts).strftime('%Y%m%d-%H%M%S')+"\n")
            canaryfh.close()
        if os.path.exists(checkfile):
            logging.info("checkfile found: "+checkfile)

            fs_type = get_fs_type(path)[0]
            logging.debug("For: "+path+" found fs type: "+fs_type)
            if expected_fs and expected_fs != fs_type:
                logging.error("ABORTING "+path+": fs type does not match expected fs - found: "+fs_type+" expected: "+expected_fs)
                error_count=error_count+1
                return

            remote_fs_type = get_remote_fs_type(remote, remotepath)
            logging.debug("For: "+remote+remotepath+": found fs type: "+remote_fs_type)
            if expected_remote_fs and expected_remote_fs != remote_fs_type:
                logging.error("ABORTING "+remote+remotepath+": fs type does not match expected fs - found: "+remote_fs_type+" expected: "+expected_remote_fs)
                error_count=error_count+1
                return

            logging.debug("RSYNC command: "+command)
            process = Popen(command,stderr=PIPE,stdout=PIPE,shell=True)
            data = process.communicate()[0]

            for line in data.splitlines():
                logging.info("RSYNC: "+line)

            if process.returncode!=0:
                # https://git.samba.org/?p=rsync.git;a=blob_plain;f=support/rsync-no-vanished;hb=HEAD
                if process.returncode==24:
                    regex = re.compile(r'^(file has vanished: |rsync warning: some files vanished before they could be transferred)', re.MULTILINE)
                    matches = [m.groups() for m in regex.finditer(data)]

                    if len(matches) > 0:
                        logging.info(path+" competed successfully")
                    else:
                        logging.error("ERROR found running job for "+path)
                        error_count=error_count+1
                else:
                    logging.error("ERROR found running job for "+path)
                    error_count=error_count+1
            else:
                logging.info(path+" competed successfully")
        else:
            logging.error("ABORTING "+path+": check file does NOT exists: "+checkfile)
            error_count=error_count+1
    else:
        logging.info("DRY RUN: "+command)

try:
    opts, args = getopt.getopt(sys.argv[1:], "hc:bdS:", ["--help", "--config", "--syncback", "--dryrun", "--canarystring"])
except getopt.GetoptError, err:
    help()
    sys.exit(3)

config_file = './rsyncman.config'
syncback = False
canary_string = ''

for opt, value in opts:
    if opt in ("-h", "--help"):
        help()
        sys.exit(3)
    elif opt in ("-c", "--config"):
        config_file = value
    elif opt in ("-b", "--syncback"):
        syncback = True
    elif opt in ("-d", "--dryrun"):
        execute_rsync = False
    elif opt in ("-S", "--canarystring"):
        canary_string = value
    else:
        assert False, "unhandled option"
        help()

logFormatter = logging.Formatter("%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s]  %(message)s")
rootLogger = logging.getLogger()

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(logFormatter)
rootLogger.addHandler(consoleHandler)

if not os.path.isfile(config_file):
    logging.error("Error - config file NOT FOUND ("+config_file+")")
    sys.exit(1)

if not access(config_file, R_OK):
    logging.error("Error reading config file ("+config_file+")")
    sys.exit(1)

try:
    config = SafeConfigParser()
    config.read(config_file)
except Exception, e:
    logging.error("error reading config file - ABORTING - "+str(e))
    sys.exit(1)

try:
    logdir=config.get('rsyncman', 'logdir').strip('"').strip("'").strip()
except:
    logdir=os.path.dirname(os.path.abspath(config_file))

ts = time.time()

logFile = "{0}/{1}/{2}-{3}.log".format(logdir, datetime.datetime.fromtimestamp(ts).strftime('%Y%m%d'), 'rsyncman', datetime.datetime.fromtimestamp(ts).strftime('%Y%m%d-%H%M%S'))

current_day_dirname = os.path.dirname(logFile)

try:
    os.makedirs(current_day_dirname)
except Exception, e:
    logging.debug("WARNING - error creating log directory: "+current_day_dirname+" - "+str(e))

fileHandler = logging.FileHandler(logFile)
fileHandler.setFormatter(logFormatter)
rootLogger.addHandler(fileHandler)

rootLogger.setLevel(0)

try:
    to_addr=config.get('rsyncman', 'to').strip('"').strip("'").strip()
except:
    to_addr=''

try:
    id_host=config.get('rsyncman', 'host-id').strip('"').strip("'").strip()
except:
    id_host=socket.gethostname()

try:
    global_pre_script=config.get('rsyncman', 'pre-script').strip('"').strip("'").strip()
except:
    global_pre_script=''

try:
    global_post_script=config.get('rsyncman', 'post-script').strip('"').strip("'").strip()
except:
    global_post_script=''

#
# pre script
#
if global_pre_script:
    logging.info("PRE script command: "+global_pre_script)
    if execute_rsync:
        logging.debug("RUNNING PRE script command: "+global_pre_script)
        prescript_process = Popen(global_pre_script,stderr=PIPE,stdout=PIPE,shell=True)
        prescript_data = prescript_process.communicate()[0]

        for line in prescript_data.splitlines():
            logging.info("pre script: "+line)

        prescript_returncode=prescript_process.returncode

        if prescript_returncode!=0:
            logging.error("pre script returned "+str(prescript_returncode)+" - expected: 0")
            error_count=error_count+1
else:
    prescript_returncode=0

if len(config.sections()) > 0:

    if prescript_returncode==0:
        for path in config.sections():
            if path != "rsyncman":
                try:
                    ionice='ionice '+config.get(path, 'ionice').strip('"').strip("'").strip()+' '
                except:
                    ionice=''

                try:
                    expected_fs=config.get(path, 'expected-fs').strip('"').strip("'").strip()
                except:
                    expected_fs=''

                try:
                    expected_remote_fs=config.get(path, 'expected-remote-fs').strip('"').strip("'").strip()
                except:
                    expected_remote_fs=''

                try:
                    default_reverse=config.getboolean(path, 'default-reverse')
                except:
                    default_reverse=False

                try:
                    if config.getboolean(path, 'compress'):
                        compress='-z '
                except:
                    compress=''

                try:
                    rsyncpath='--rsync-path="'+config.get(path, 'rsync-path').strip('"').strip("'").strip()+'"'
                except:
                    rsyncpath=''

                try:
                    if os.path.isabs(config.get(path, 'check-file').strip('"').strip("'").strip()):
                        checkfile=config.get(path, 'check-file').strip('"').strip("'").strip()
                    else:
                        checkfile=path+'/'+config.get(path, 'check-file').strip('"').strip("'").strip()
                except:
                    checkfile=path

                try:
                    if config.getboolean(path, 'delete'):
                        delete='--delete '
                    else:
                        delete=''
                except:
                    delete=''

                try:
                    exclude_config_get = config.get(path,'exclude')
                    try:
                        exclude=' '
                        for item in json.loads(exclude_config_get):
                            exclude+='--exclude '+item+' '
                    except Exception, e:
                        logging.error("error reading excludes for  "+path+" - ABORTING - "+str(e))
                        error_count=error_count+1
                        continue
                except:
                    exclude=' '

                try:
                    exclude_from="--exclude-from "+config.get(path, 'exclude-from').strip('"').strip("'").strip()+' '
                except:
                    exclude_from=''

                try:
                    remotepath=config.get(path, 'remote-path').strip('"').strip("'").strip()
                except:
                    remotepath=os.path.dirname(path)

                try:
                    remote=config.get(path, 'remote').strip('"').strip("'").strip()
                    if remote:
                        remote=remote+":"
                except Exception, e:
                    logging.error("remote is mandatory, aborting rsync for "+path+" - "+str(e))
                    error_count=error_count+1
                    continue

                try:
                    if os.path.isabs(config.get(path, 'canary-file').strip('"').strip("'").strip()):
                        logging.error(path+": canary file cannot be an absolute path")
                        error_count=error_count+1
                        continue
                    else:
                        if syncback:
                            canaryfile=remotepath+'/'+config.get(path, 'canary-file').strip('"').strip("'").strip()
                        else:
                            canaryfile=path+'/'+config.get(path, 'canary-file').strip('"').strip("'").strip()
                        logging.debug("canary file: "+canaryfile)
                except:
                    canaryfile=''

                runJob(ionice,delete,exclude,rsyncpath,path,remote,remotepath,checkfile,expected_fs,expected_remote_fs,syncback,canaryfile,canary_string,exclude_from,default_reverse,compress)

    if global_post_script:
        logging.info("POST script command: "+global_post_script)
        if execute_rsync:
            logging.debug("RUNNING post script command: "+global_post_script)
            postscript_process = Popen(global_post_script,stderr=PIPE,stdout=PIPE,shell=True)
            postscript_data = postscript_process.communicate()[0]

            for line in postscript_data.splitlines():
                logging.info("post script: "+line)

            postscript_returncode=postscript_process.returncode

            if postscript_returncode!=0:
                logging.error("post script returned "+str(postscript_returncode)+" - expected: 0")
                error_count=error_count+1

    if error_count >0:
        logging.error("ERRORS FOUND: "+str(error_count))
    else:
        logging.info("SUCCESS")

    if to_addr:
        sendReportEmail(to_addr, id_host)

else:
    logging.error("No config found")
    sys.exit(1)
