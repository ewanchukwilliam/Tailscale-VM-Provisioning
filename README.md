# Tailscale-VM-Provisioning

this will contain the configurations required to deploy my NAS tailscale node onto my proxmox cluster. 

## requirements
- ansible 
- terraform 
- github actions

This repo provisions and maintains a remote NAS service on a Proxmox cluster using Terraform, Ansible, and GitHub Actions. The design uses option 2: the Proxmox host mounts the large RAID-backed filesystem directly and keeps ownership of the real storage, while only a specific subfolder is shared into a dedicated Debian NAS VM. The storage node acts as a storage hub for backups and file sharing, not as hot shared storage for the rest of the cluster. The NAS VM is intentionally disposable and rebuildable, while the host-owned filesystem remains persistent.

Terraform is responsible only for infrastructure provisioning. It should create the Debian NAS VM in Proxmox, configure CPU, memory, disk, networking, cloud-init, and any VM-level settings needed for the NAS role. Ansible is responsible for guest configuration after provisioning and for ongoing configuration enforcement. It should install and configure Samba for SMB file sharing, install and configure Tailscale inside the VM only, mount the shared host folder inside the VM, create users and groups, apply permissions, and template the Samba configuration. The SMB share should be reachable remotely from macOS Finder over Tailscale using `smb://...`, without exposing SMB publicly to the internet and without routing SMB through NGINX.

GitHub Actions should be used to automatically reapply and refresh server configuration through Ansible so changes can be committed to the repo and deployed without manually SSHing into the VM to remember setup steps. On pushes or merges, GitHub Actions should run validation steps and then run Ansible to ensure the NAS VM still matches the desired state, including installed packages, mounts, paths, permissions, and service configuration. This is meant to support config refresh and drift correction, not require destroying and reprovisioning the VM for normal changes. For example, if a mounted RAID path, Samba share path, permissions, or service configuration changes in the repo, GitHub Actions should apply that change automatically through Ansible.

Secrets must not be committed to the repo. Proxmox API credentials, Tailscale auth keys, Samba passwords, and SSH private keys should be injected through GitHub secrets, local environment variables, or encrypted Ansible Vault files. The final goal is a reproducible repo that provisions a Debian NAS VM on Proxmox, attaches a host-owned storage path using option 2, keeps that VM configured through repeatable Ansible runs, and exposes files to macOS through Finder using SMB over the Tailscale network rather than public port forwarding.

## TODO
- [x] Fill in terraform/main.tf (node name, IP, gateway, mount path)
- [x] Fill in terraform/terraform.tfvars with Proxmox credentials and SSH key
- [x] Fill in ansible/inventory.ini with container IP and ProxyJump details
- [x] Configure host-side bind mount for RAID share into the LXC container
- [x] Test terraform apply locally
- [x] Add GitHub secrets for SSH, Proxmox, and desktop
- [ ] Add TAILSCALE_AUTH_KEY GitHub secret
- [ ] Add SAMBA_USER_PASSWORD GitHub secret
- [ ] Generate a Tailscale auth key from the admin console
- [ ] Verify Tailscale connects and container gets a Tailscale IP
- [ ] Verify SMB access from macOS Finder over Tailscale (`smb://tailscale-ip/nas`)
testing tailsclae auth key

