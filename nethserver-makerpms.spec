Name:           nethserver-makerpms
Version: 0.0.0
Release: 1%{?dist}
Summary:        RPM build automation scripts for NethServer packages
BuildArch:	noarch

License:        GPLv3
URL:            http://www.nethserver.org
Source0:        %{name}-%{version}.tar.gz

Requires: buildah

%description
Provides build automation for NethServer packages based on Linux containers

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}/%{_sbindir}
install -vp src/sbin/* %{buildroot}/%{_sbindir}

%files
%defattr(-,root,root,-)
%{_sbindir}/makerpms
%{_sbindir}/makesrpm
%doc LICENSE

%changelog
* Fri Nov 10 2017 Davide Principi <davide.principi@nethesis.it> - 0.0.0-1
- Initial alpha version

* Fri Nov 10 2017 Davide Principi <davide.principi@nethesis.it> - 0.0.0-1
- Initial version
