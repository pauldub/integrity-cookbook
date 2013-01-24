#
# Cookbook Name:: integrity
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'git'

user node[:integrity][:user]

package 'ruby' do
  action :install
end

gem_package 'bundler' do
  action :install
end

package 'libxml2-dev' do
  action :install
end

package 'libxslt1-dev' do
  action :install
end

directory "#{node[:integrity][:path_prefix]}/integrity" do
  action :delete
  recursive true
end

bash 'post_install' do
  action :nothing
  code <<-EOF
    git checkout -b deploy master
    bundle install
    bundle exec rake db
  EOF
  cwd "#{node[:integrity][:path_prefix]}/integrity"
end

git "#{node[:integrity][:path_prefix]}/integrity" do
  repository node[:integrity][:repository]
  user node[:integrity][:user]
  action :sync

  notifies :run, 'bash[post_install]'
end

template "#{node[:integrity][:path_prefix]}/integrity/init.rb" do
  source 'init.rb.erb'
  owner node[:integrity][:user]
  group node[:integrity][:user]
end

template "#{node[:integrity][:path_prefix]}/integrity/doc/thin.yml" do
  source 'thin.yml.erb'
  owner node[:integrity][:user]
  group node[:integrity][:user]
end
