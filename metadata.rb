name              "django"
maintainer        "Alex Kamedov"
maintainer_email  "alex@kamedov.ru"
license           "New BSD"
description       "Installs needed recipies and executes commands to install python packages using pip."
version           "0.0.2"

depends 'apt'
depends 'yum'
depends 'postgresql'
depends 'postgis'
depends 'python'

recipe "django", "Installs several python packages via pip"

%w{ debian ubuntu centos redhat fedora freebsd smartos }.each do |os|
  supports os
end
