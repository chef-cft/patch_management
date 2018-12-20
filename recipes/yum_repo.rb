#
# Cookbook Name:: patch_management
# Recipe:: yum_repo
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

# TODO: Look into replacing pakrat with native functionality.

package 'createrepo'
package 'python-setuptools'
package 'httpd'

# https://github.com/ryanuber/pakrat
execute 'easy_install pakrat'

repos = ''
node['yum']['repos'].each do |name, baseurl|
  repos += "--name #{name} --baseurl #{baseurl} "
end

repos += '--combined ' if node['yum']['combined']

directory '/var/www/html/' do
  recursive true
end

execute 'background pakrat repository sync' do
  cwd '/var/www/html/'
  command "pakrat #{repos} --repoversion $(date +%Y-%m-%d)"
  live_stream true
end

service 'httpd' do
  action [:start, :enable]
end
