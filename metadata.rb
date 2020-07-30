name 'patch_management'
maintainer 'Chef Software, Inc'
maintainer_email 'success@chef.io'
license 'Apache-2.0'
description 'Sample Patch Management Cookbook'
version '0.1.1'

depends 'wsus-client'
depends 'wsus-server'
depends 'yum' unless platform?('rhel')
depends 'apt' unless platform?('debian') 
