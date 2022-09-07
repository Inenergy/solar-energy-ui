cd "$( dirname "$0" )/.."

# MAIN APP INSTALLATION
npm i
npm run build

# MAIN APP AUTOSTART
chmod +x dist/solar-energy-ui*.AppImage
mkdir -p ~/inenergy-gui/dist
cp dist/solar-energy-ui*.AppImage ~/inenergy-gui/dist/
mkdir ~/.inenergy
echo '~/inengergy-gui/dist/solar-energy-ui*.AppImage > ~/.inenergy/solar-energy-ui.log' > ~/.config/openbox/autostart