part of dart_gl;


/*
 * Single frame
 */
class AnimFrame
{
    AnimFrame(this.frameData, this.duration);

    BaseRenderable frameData;
    double         duration;
}


/*
 * Basic animated sprite
 */
class Animation
{
    int     _currentFrame;
    double  _currFrameDuration;
    Vector3 animScale;
    Vector3 animRotation;
    Vector3 animPosition;
    Vector2 animPivot;

    List<AnimFrame> frames;

    Animation(this.animPosition)
    {
        this._currentFrame = 0;
        this._currFrameDuration = 0.0;
        this.frames       = new List<AnimFrame>();
        this.animScale    = new Vector3(1.0, 1.0, 1.0);
        this.animRotation = new Vector3(0.0, 0.0, 0.0);       
        this.animPivot    = new Vector2(0.0, 0.0);        
    }
    
    void OnNewFrame(double dt)
    {
        if(frames.length <= 0)
        {
            print("Animation has no frames");
            return;
        }

        // loop animations
        _currFrameDuration += dt;

        if(_currFrameDuration >= frames[_currentFrame].duration)
        {
            _currFrameDuration = 0.0;
            ++_currentFrame;

            if (_currentFrame >= frames.length)
            {
                _currentFrame = 0;
            }
        }

        frames[_currentFrame].frameData.position = animPosition;
        frames[_currentFrame].frameData.scale    = animScale;
        frames[_currentFrame].frameData.rotation = animRotation;
        frames[_currentFrame].frameData.pivot    = animPivot;
        frames[_currentFrame].frameData.OnNewFrame(dt);
    }

    
    /*
     * Add animation frame
     */
    void AddFrame(BaseRenderable frameData, String texName, num duration)
    {
        frameData.texture = texMgr.bindTexture(texName);
        frames.add(new AnimFrame(frameData, duration));
    }
}