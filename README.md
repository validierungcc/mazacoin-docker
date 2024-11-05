**Maza Coin**

https://github.com/MazaCoin/maza

https://mazacoin.org/


Example docker-compose.yml

     ---
    services:
        maza:
            container_name: maza
            image: vfvalidierung/mazacoin
            restart: unless-stopped
            ports:
                - '12835:12835'
                - '127.0.0.1:12832:12832'
            volumes:
                - 'maza:/maza/.maza'
    volumes:
       maza:

**RPC Access**

    curl --user 'mazarpc:<password>' --data-binary '{"jsonrpc":"2.0","id":"curltext","method":"getinfo","params":[]}' -H "Content-Type: application/json" http://127.0.0.1:12832
