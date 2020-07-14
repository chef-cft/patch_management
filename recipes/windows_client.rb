#
# Cookbook:: patch_management
# Recipe:: windows_client
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

return unless platform_family?('windows')

powershell_script 'Configure Shell Memory' do
  code 'Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 2048'
end

include_recipe 'wsus-client::configure'

# Force a scan. This is for demo only, let the timers manage the scans.
# It make take a day or two to get all your data but it will reduce the
# load on your WSUS server.
execute 'Run SUS scan' do
  command 'c:\\windows\\system32\\UsoClient.exe startscan'
  action :run
end
