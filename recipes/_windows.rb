#
# Cookbook Name:: patch_management
# Recipe:: _windows
#
# Copyright 2016 Chef Software, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

return unless platform_family?('windows')

powershell_script 'Configure Shell Memory' do
  code 'Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048'
end

node.default['wsus_client']['wsus_server'] = 'http://192.168.254.72:8530'
node.default['wsus_client']['update_group'] = node['patch']['version']

include_recipe 'wsus-client::configure'

reboot 'Restart Computer' do
  action :nothing
  only_if { reboot_pending? }
end

wsus_client_update 'WSUS updates' do
  action [:download, :install]
  notifies :reboot_now, 'reboot[Restart Computer]'
end
