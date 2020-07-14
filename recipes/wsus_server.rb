#
# Cookbook:: patch_management
# Recipe:: wsus_server
#
# Copyright:: 2016 Chef Software, Inc
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
  action :nothing
  code 'Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048'
end.run_action(:run)

include_recipe 'wsus-server'
include_recipe 'wsus-server::freeze'

powershell_script 'Set WSUS App Pool max mem' do
  code <<-EOH
  import-module webadministration
  Set-WebConfiguration "/system.applicationHost/applicationPools/add[@name='WsusPool']/recycling/periodicRestart/@privateMemory" -Value 4096000
  EOH
  not_if "import-module webadministration; if ($(Get-WebConfiguration \"/system.applicationHost/applicationPools/add[@name='WsusPool']/recycling/periodicRestart/@privateMemory\").value -eq 4096000){return $true}"
end
