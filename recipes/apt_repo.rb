#
# Cookbook:: patch_management
# Recipe:: apt_repo
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

return unless platform_family?('debian')

execute 'Refresh package list' do
  command 'apt update'
  action :run
end

package 'apt-mirror'
package 'apache2'

template '/etc/apt/mirror.list' do
  source 'mirror.list.erb'
  action :create
end

directory '/var/www/html/ubuntu' do
  owner 'www-data'
  action :create
end

execute 'Sync Mirror' do
  command 'apt-mirror'
  action :run
end

# Create Symlink for apache to serve the mirror dir

# Make sure apache can follow the symlinks

# Edit /etc/cron.d/apt-mirror to schedule automated sync's

service 'apache2' do
  action [ :enable, :start ]
end
