#!/usr/local/bin/bash -ux
# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
RUBY_VERSION=1.9.3
RUBY_DEFAULT_VER=1.9
EOT

#Off to rubygems to get first ruby running
cd /usr/ports/devel/ruby-gems
make install -DBATCH

#Need ruby iconv in order for chef to run
cd /usr/ports/converters/ruby-iconv
make install -DBATCH

