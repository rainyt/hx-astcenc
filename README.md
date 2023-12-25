# hx-astcenc
 Create ASTC format texture file.

# Use
```shell
haxelib run hx-astcenc c -cl ./ChristGiftViewAtlas.png ./texture_zilb.astc 4x4 -exhaustive -pp-premultiply
```

# Json Config
Use Json data create all ASTC file.
```json
[
    {
        "zlib": true,
        "mode": "-cl",
        "defaultBlock": "6x6",
        "quality": "-exhaustive",
        "alphaPremultiply": true,
        "path": "Assets",
        "output": "Assets_astc",
        "igroneError": true
    },
    {
        "zlib": true,
        "mode": "-cl",
        "defaultBlock": "4x4",
        "quality": "-exhaustive",
        "alphaPremultiply": true,
        "path": "../../Assets2",
        "output": "Assets_astc",
        "igroneError": true
    }
]
```
Command:
```shell
haxelib run hx-astcenc file.json
```