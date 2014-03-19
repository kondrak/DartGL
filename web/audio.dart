part of dart_gl;

// sounds to load
const soundList = const {
    'example'  : 'sounds/sample.ogg',
};

typedef void OnLoadCallback(List<AudioBuffer> bufferList);

/*
 * Async audio loader
 */
class SoundLoader
{
    final AudioContext _audioCtx;
    int                _loadCount;
    List<AudioBuffer>  _bufferList;    
    List<String>       urlList;
    OnLoadCallback     callback;

    
    SoundLoader(this._audioCtx, this.urlList, this.callback) 
    {
        _loadCount  = 0;
        _bufferList = new List<AudioBuffer>(urlList.length);
    }

    
    void Load() 
    {
        for (var i = 0; i < urlList.length; i++) {
            _loadSound(urlList[i], i);
        }
    }

    
    void _loadSound(String url, int index) 
    {
        // Load the buffer asynchronously.
        var request = new HttpRequest();
        request.open("GET", url, async: true);
        request.responseType = "arraybuffer";
        request.onLoad.listen((e) => _onLoad(request, url, index));

        request.onError.listen((e) => throw "Error loading sound: $url");

        request.send();
    }

    
    void _onLoad(HttpRequest request, String url, int index) 
    {
        _audioCtx.decodeAudioData(request.response).then((AudioBuffer buffer) {
            if (buffer == null)
            {
                throw "Error decoding sound: $url";
            }

            _bufferList[index] = buffer;
            if (++_loadCount == urlList.length) callback(_bufferList);
        });
    }
}


class AudioSound
{
    AudioSound(this.sndBuffer);

    AudioBufferSourceNode _source;
    AudioBuffer sndBuffer;
}

/*
 * The class interface for playing sounds
 */
class AudioManager
{
    AudioContext _audioCtx;
    bool         allSoundsLoaded;
    bool         soundSupported;

    Map<String, AudioSound> _soundList;
    
    
    AudioManager()
    {
        try
        {
            _audioCtx  = new AudioContext();
            _soundList = new Map<String, AudioSound>();
            allSoundsLoaded = false;
            soundSupported  = true;
            _loadSounds();
        }
        catch (e)
        {
            allSoundsLoaded = true;
            soundSupported  = false;
            print(e);
        }
    }

    void _loadSounds() {
        List<String> names = soundList.keys.toList();
        List<String> paths = soundList.values.toList();

        SoundLoader loader = new SoundLoader(_audioCtx, paths, (List<AudioBuffer> bufferList) {
            // all sounds loaded, create internal representations
            for (var i = 0; i < bufferList.length; i++) {
                AudioBuffer buffer = bufferList[i];
                String name = names[i];
                
                _soundList[name] = new AudioSound(buffer);
            }
            
            allSoundsLoaded = true;
        });

        loader.Load();
    }

    
    bool Play(String sndName, [bool looped = false])
    {
        if(soundSupported == false)
            return false;

        _soundList[sndName]._source = _audioCtx.createBufferSource();
        _soundList[sndName]._source.buffer = _soundList[sndName].sndBuffer;
        _soundList[sndName]._source.connectNode(_audioCtx.destination, 0, 0);

        _soundList[sndName]._source.start(0);
        _soundList[sndName]._source.loop = looped;

        return _soundList[sndName]._source.playbackState == AudioBufferSourceNode.PLAYING_STATE;
    }

    
    bool Stop(String sndName)
    {
        if(soundSupported == false)
            return true;

        _soundList[sndName]._source.stop(0);
        return _soundList[sndName]._source.playbackState != AudioBufferSourceNode.PLAYING_STATE;
    }

    
    bool isPlaying(String sndName)
    {
        if(soundSupported == false)
            return false;

        if(_soundList[sndName]._source != null)
            return (_soundList[sndName]._source.playbackState == AudioBufferSourceNode.PLAYING_STATE);

        return false;
    }

    
    void Toggle(String sndName, [bool looped = false])
    {
        if(soundSupported == false)
            return;

        if(_soundList[sndName]._source != null)
            isPlaying(sndName) ? Stop(sndName) : Play(sndName, looped);
        else
            Play(sndName, looped);
    }
}