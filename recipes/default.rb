#
# Cookbook:: nxlog
# Recipe:: default
#
# Copyright:: (C) 2014 Simon Detheridge
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
#

case node['platform_family']
when 'debian'
  if platform?('ubuntu')
    include_recipe 'sc-nxlog::ubuntu'
  else
    include_recipe 'sc-nxlog::debian'
  end
when 'rhel'
  include_recipe 'sc-nxlog::redhat'
when 'windows'
  include_recipe 'sc-nxlog::windows'
else
  raise('Attempted to install on an unsupported platform')
end

package_name = node['nxlog']['installer_package']

if node['nxlog']['checksums'][package_name]
  remote_file 'nxlog' do
    path "#{Chef::Config[:file_cache_path]}/#{package_name}"
    source "#{node['nxlog']['package_source']}/#{package_name}"
    mode '644'
    checksum node['nxlog']['checksums'][package_name]
  end
else
  remote_file 'nxlog' do
    path "#{Chef::Config[:file_cache_path]}/#{package_name}"
    source "#{node['nxlog']['package_source']}/#{package_name}"
    mode '644'
  end
end

if platform?('ubuntu', 'debian')
  dpkg_package 'nxlog' do
    source "#{Chef::Config[:file_cache_path]}/#{package_name}"
    options '--force-confold'
  end
else
  package 'nxlog' do
    source "#{Chef::Config[:file_cache_path]}/#{package_name}"
  end
end

service 'nxlog' do
  action %i(enable start)
end

template "#{node['nxlog']['conf_dir']}/nxlog.conf" do
  source 'nxlog.conf.erb'

  notifies :restart, 'service[nxlog]', :delayed
end

directory "#{node['nxlog']['conf_dir']}/nxlog.conf.d"

include_recipe 'sc-nxlog::resources_from_attributes'
