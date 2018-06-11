name 'sauron_cookbook'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures sauron_cookbook'
long_description 'Installs/Configures sauron_cookbook'
version '0.0.1'
chef_version '>= 12.14' if respond_to?(:chef_version)

depends 'tar'
depends 'postgresql'
