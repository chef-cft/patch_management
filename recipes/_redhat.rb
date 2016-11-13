#
# Cookbook Name:: patch_management
# Recipe:: _redhat
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

return unless platform_family?('rhel')

::Dir.glob('/etc/yum.repos.d/*.repo').each do |repo|
  file repo do
    action :delete
    not_if { ::File.exist?('/etc/yum.repos.d/.chef_managed') }
  end
end

node['yum']['repos'].each do |name, _|
  yum_repository name do
    baseurl "http://192.168.254.71/#{name}/#{node['patch']['version']}"
    gpgcheck false
  end
end

reboot 'Restart Computer' do
  action :nothing
  only_if { reboot_pending? } # TODO: This won't actually work on RHEL
end

execute 'yum update -y' do
  notifies :reboot_now, 'reboot[Restart Computer]'
end
