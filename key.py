import os

# Create the .ssh directory in the current working directory
ssh_dir = "./.ssh"
os.makedirs(ssh_dir, exist_ok=True)

# Define the file paths
ssh_key_path = os.path.join(ssh_dir, "id_rsa")
ssh_pub_key_path = os.path.join(ssh_dir, "id_rsa.pub")
output_file_path = "./ssh_key.txt"

# Remove existing key files if they exist
if os.path.exists(ssh_key_path):
    os.remove(ssh_key_path)
if os.path.exists(ssh_pub_key_path):
    os.remove(ssh_pub_key_path)

# Generate the SSH key pair
os.system(f'ssh-keygen -t rsa -b 4096 -C "wjrahe@gmail.com" -f {ssh_key_path} -N ""')

# Read the public key
if os.path.exists(ssh_pub_key_path):
    with open(ssh_pub_key_path, "r") as file:
        public_key_content = file.read()

    # Write the public key to a text file
    with open(output_file_path, "w") as output_file:
        output_file.write(public_key_content)

    print(f"Public key has been written to: {output_file_path}")
else:
    print("Public key file not found. SSH key generation may have failed.")
