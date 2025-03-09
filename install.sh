#!/bin/bash
# filepath: /home/idk/go/src/i2pgit.org/idk/graphic-monitoring/install.sh

CONKY_CONF_DIR="$HOME/.config/conky"

# Check if conky is installed
if ! command -v conky >/dev/null 2>&1; then
    echo "Conky is not installed. Please install it first."
    sudo apt-get install -y conky-all
    echo "Conky installed successfully."
fi

# Create required directories
mkdir -p "$CONKY_CONF_DIR"
mkdir -p ~/.local/share/conky/lua/json4lua/json

# Install lua dependencies if not already present
if ! command -v luarocks >/dev/null 2>&1; then
    echo "Installing luarocks..."
    sudo apt-get install -y luarocks
fi

# Install json4lua using luarocks
sudo luarocks install json4lua

# Copy configuration files
cp _dot_conkyrc "$CONKY_CONF_DIR"/config
cp -r lua/* ~/.local/share/conky/lua/

# Create startup script
cat > ~/.config/autostart/conky-i2p.desktop << EOF
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky -c "$CONKY_CONF_DIR"/config
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Set permissions
chmod +x ~/.config/autostart/conky.desktop

echo "Installation complete! You can start conky by running:"
echo "conky -c "$CONKY_CONF_DIR"/config"
echo "Or logout and login again for autostart to take effect."