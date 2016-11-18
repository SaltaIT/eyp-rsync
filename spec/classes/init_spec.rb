
require 'spec_helper'

describe 'rsync' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "rsync class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_service('rsync') }
          it { is_expected.to contain_package('rsync').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'rsync class without any parameters' do
      let(:facts) do
        {
          :osfamily        => 'SOFriki',
          :operatingsystem => 'SOFregit',
        }
      end

      it {
        expect { should raise_error(Puppet::Error) }
      }
    end
  end
end
