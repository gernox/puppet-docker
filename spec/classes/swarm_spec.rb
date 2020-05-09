require 'spec_helper'

describe 'gernox_docker::swarm', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'compile' do
        let(:params) do
          {
            manager_ip: '1.2.3.4',
            ipaddress: '4.3.2.1',
            join_token: 'winteriscoming',
            hostname: 'johnsnow',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('gernox_docker') }
        it {
          is_expected.to contain_docker__swarm('swarm_johnsnow')
            .with(
              'manager_ip' => '1.2.3.4',
              'advertise_addr' => '4.3.2.1',
              'listen_addr' => '4.3.2.1',
              'token' => 'winteriscoming',
              'join' => true,
              'init' => false,
            )
        }
      end
    end
  end
end
