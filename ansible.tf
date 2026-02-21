resource "local_file" "ansible-inventory" {
  content = <<EOF
[web]
${aws_instance.my-machine.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${path.root}/keys/rsa-4096.pem
EOF
    filename = "${path.root}/ansible/inventory.ini"
}

resource "local_file" "ansible-playbook" {
  content = <<EOF
- name: Setup EC2 base
  hosts: web
  become: yes

  tasks:
    - name: Update APT cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name:
          - nginx
        state: present

    - name: Check if Nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
EOF
    filename = "${path.root}/ansible/setup.yml"
}