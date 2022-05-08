Snapcast-Shairport

Private local MultiRoom-Setup

Docker image providing Snapcastserver with Shairport enabled
So you can stream form i-Devices to your snapcast setup
Needs Host network for now to show up as Airplay-Device

Plan is to add other input possibilities


docker build -t local/snapcast-shairport .
docker run --net host local/snapcast-shairport 