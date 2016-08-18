name              "django"
maintainer        "Alex Kamedov"
maintainer_email  "alex@kamedov.ru"
license           "New BSD"
description       "Installs needed recipies and executes commands to install python packages using pip."
version           "0.0.1"

depends           "apt"

recipe "django", "Installs several python packages via pip"

%w{ debian ubuntu centos redhat fedora freebsd smartos }.each do |os|
  supports os
end
