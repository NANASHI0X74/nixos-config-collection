
{ config, pkgs, ... }:
{
	boot.initrd = {
		network.enable = true;
		network.ssh = {
			enable = true;
			authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCslUchy7sMNYNUg9a//cgl1pG1HPoPso62VriPtmDDZ956Q9AEVMDK8FU2KVb1ZN1VONdjt4zelQyb4l/cUfoS5HzEc/qry7Q538QgeK7LECW1dXbOioxUL7WcpVR07RJVofoD2mNlyyOGB62wusX9SYWUqDFgjWZj0g2fUzR2lsklRsEEM8ZFGLytmYpJ0FIeOSidn8XM+qHErTTTRrLjEDGTgkmtUFaTVzRobiGnkr5SyDx8uUWqagotoct62HOLb2n01JmJvLqCFbrBdUBgC+jSSwgygqZTGWPD5mxaH9tvBLhNt+7apNc19fNCio8JoxVUyqsBqa12hKeZPK6E4eoUPpK6HWk/LtGRUKYeO01aRa3uqK+VAKHSECss+TuVfcnhKbi8u+AJ9PnrVur7+tC9xlqAf+J154sVGZy6GPYD5zxtskTBqdB93BBko16eB9iKxgPw7uu/4tU1pY1ypRyxzkk4tjLlgX5/Wz0fOv/PXT9LnBYLUD/V2PdUmmc= rian@rian-ThinkPad-S3-Yoga-14
		"];
			# need to be created beforehand
			# nix-shell -p dropbear --command "dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key"
			hostDSSKey = /etc/dropbear/dropbear_dss_host_key;
			# nix-shell -p dropbear --command "dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key"
			hostECDSAKey = /etc/dropbear/dropbear_ecdsa_host_key;
			# nix-shell -p dropbear --command "dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key"
			hostRSAKey = /etc/dropbear/dropbear_rsa_host_key;
			port = 7474;
		};
	};
}
