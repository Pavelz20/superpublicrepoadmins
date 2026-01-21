cat > /etc/apt/apt.conf.d/90-proxy.conf << 'EOF'
Acquire::http::Proxy "http://proxy.tech.skills:3128";
Acquire::https::Proxy "http://proxy.tech.skills:3128";
EOF

cat > /etc/apt/sources.list.d/aldpro.list << 'EOF'
deb https://dl.astralinux.ru/aldpro/frozen/01/3.0.0/ 1.7_x86-64 main base
EOF

cat > /etc/apt/sources.list << 'EOF'
deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.7/repository-main/ 1.7_x86-64 main contrib non-free
deb http://dl.astralinux.ru/astra/frozen/1.7_x86-64/1.7.7/repository-update/ 1.7_x86-64 main contrib non-free
EOF

