require 'spec_helper'

describe 'gernox_docker', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'not passing parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_class('docker')
            .with(
              'tcp_bind' => 'tcp://0.0.0.0:2375',
            )
        }
        it { is_expected.to contain_file('/etc/systemd/system/docker-system-prune.service').with_content(%r{[Service]}) }
        it { is_expected.to contain_file('/etc/systemd/system/docker-system-prune.timer').with_content(%r{[Timer]}) }
        it { is_expected.to contain_service('docker-system-prune') }
      end

      describe 'with listen address and port parameters' do
        let(:params) do
          {
            listen_address: '127.0.0.1',
            listen_port: 4711,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_class('docker')
            .with(
              'tcp_bind' => 'tcp://127.0.0.1:4711',
            )
        }
      end
    end
  end
end
