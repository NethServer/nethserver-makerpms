Name:           nethserver-makerpms
Version:        0.0.0
Release:        1%{?dist}
Summary:        RPM build automation scripts for NethServer packages
BuildArch:      noarch

License:        GPLv3
URL:            http://www.nethserver.org
Source0:        %{name}-%{version}.tar.gz

Requires: podman

%description
Provides build automation for NethServer packages based on Linux containers

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}/%{_bindir}
mkdir -p  %{buildroot}/%{_datarootdir}/%{name}/
find $(pwd)
install -vp src/bin/* %{buildroot}/%{_bindir}
install -vp buildimage/* %{buildroot}/%{_datarootdir}/%{name}

%files
%defattr(-,root,root,-)
%{_bindir}/makerpms
%{_bindir}/makesrpm
%{_bindir}/uploadrpms
%{_datarootdir}/%{name}/
%doc LICENSE

%changelog
* Fri Nov 10 2017 Davide Principi <davide.principi@nethesis.it> - 0.0.0-1
- Initial alpha version

* Fri Nov 10 2017 Davide Principi <davide.principi@nethesis.it> - 0.0.0-1
- Initial version
