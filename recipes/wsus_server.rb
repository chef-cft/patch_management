#
# Cookbook Name:: patch_management
# Recipe:: wsus_server
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

powershell_script 'Configure Shell Memory' do
  code 'Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048'
end

node.default['wsus_server']['freeze']['name'] = Date.today.strftime('%Y-%m-%d')
node.default['wsus_server']['subscription']['categories'] = [
  'Windows Server 2012 R2'
]
node.default['wsus_server']['subscription']['classifications'] = [
  'All Classifications'
]
include_recipe 'wsus-server'
include_recipe 'wsus-server::freeze'

# [
#   'NET-WCF-HTTP-Activation45', # This feature is required for KB3159706
#   'UpdateServices',
#   'UpdateServices-UI'
# ].each do |feature_name|
#   windows_feature feature_name do
#     action         :install
#     all            true
#     provider       :windows_feature_powershell
#   end
# end
#
# powershell_script 'Set WSUS Products' do
#   code 'Get-WsusServer | Get-WsusProduct | Where-Object -FilterScript {$_.product.title -Like "Windows Server 2012 R2*"} | Set-WsusProduct'
# end
#
# powershell_script 'Set WSUS Categories' do
#   code 'Get-WsusClassification | Set-WsusClassification'
# end
#
# # wsus_server_configuration 'WSUS server' do
# #   update_languages ['en']
# # end
#
# # wsus_server_subscription 'WSUS server' do
# #   automatic_synchronization true
# #   categories [ 'Windows Server 2012 R2' ]
# #   classifications [ 'All Classifications' ]
# # end
