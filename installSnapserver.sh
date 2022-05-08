apt-get install -y ./$(curl -s https://api.github.com/repos/badaix/snapcast/releases/latest | jq '.assets[] | select(.name | test("snapserver.*?amd64.deb"))' | jq '.name' | sed 's/"//g')
