**Maza Coin**

https://github.com/MazaCoin/maza

https://mazacoin.org/


Example docker-compose.yml

     ---
    version: '3.9'
    services:
        maza:
            container_name: maza
            image: vfvalidierung/maza
            restart: unless-stopped
            user: 1000:1000
            ports:
                - '4555:4555'
                - '127.0.0.1:4444:4444'
            volumes:
                - 'maza:/maza/.maza'
    volumes:
       maza:

**RPC Access**

    curl --user '<user>:<password>' --data-binary '{"jsonrpc":"2.0","id":"curltext","method":"getinfo","params":[]}' -H "Content-Type: application/json" http://127.0.0.1:12832
