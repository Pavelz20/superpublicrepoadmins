cat > /etc/apt/apt.conf.d/90-proxy.conf << 'EOF'
Acquire::http::Proxy "http://proxy.tech.skills:3128";
Acquire::https::Proxy "http://proxy.tech.skills:3128";
EOF

wget http://10.150.0.200/extra/{core-snap.zip,core20-snap.zip,microk8s-snap.zip}