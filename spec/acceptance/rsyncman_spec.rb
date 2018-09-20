require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'rsync class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'rsync::manager':
      }

      rsync::manager::schedule { 'demo':
        mail_to => 'jordi@example.com',
        host_id => 'demopuppet',
      }

      rsync::manager::job { 'demo':
        path        => '/demo',
        remote      => 'jprats@127.0.0.1',
        remote_path => '/demo2',
      }


      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('rsync') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/rsyncman/demo.conf') do
      it { should be_file }
      its(:content) { should match '[rsyncman]' }
      its(:content) { should match 'to=jordi@example.com' }
      its(:content) { should match 'host-id=demopuppet' }
      its(:content) { should match 'logdir=/var/log/rsyncman' }
      its(:content) { should match '[/demo]' }
      its(:content) { should match 'delete = false' }
      its(:content) { should match 'remote="jprats@127.0.0.1"' }
      its(:content) { should match 'remote-path="/demo2"' }
    end

    #crontab -l | grep "* * * * * /usr/bin/rsyncman -c /etc/rsyncman/demo.conf"
    it "check conrtab" do
      expect(shell("crontab -l | grep \"* * * * * /usr/bin/rsyncman -c /etc/rsyncman/demo.conf\"").exit_code).to be_zero
    end

  end
end
