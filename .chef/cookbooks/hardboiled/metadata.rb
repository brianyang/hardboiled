maintainer        "Proksoup"
maintainer_email  "me@proksoup.com"
license           "MIT"
description       "Installs and configures hardboiled"
version           "0.0.1"

recipe "thlip", "Installs hardboiled"

%w{ ubuntu debian centos redhat amazon scientific oracle fedora }.each do |os|
  supports os
end

%w{ build-essential runit }.each do |cb|
  depends cb
end