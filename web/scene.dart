part of dart_gl;

/*
 * Sample scene
 */
class Scene
{
    RectObject staticObject;
    Animation sprite;  
  
    void Load()
    {
        sprite = new Animation(new Vector3(0.25, -0.25, 0.0));

        // first frame - separate texture; second frame - atlas clip
        sprite.AddFrame(new RectObject(shaderMgr.Load('basicShader'), 64, 64), 'frame1', 1000.0);
        sprite.AddFrame(new RectClipObject(shaderMgr.Load('basicShader'), 64, 64, new Vector3(0.0, 0.0, 0.0), new Vector2(16.0, 0.0)), 'atlasTex', 1000.0);

        staticObject = new RectObject(shaderMgr.Load('basicShader'), 256, 256);
        staticObject.texture = texMgr.bindTexture('wall');
    }

    
    void OnNewFrame(double dt)
    {
        GL.PushMatrix();  
        staticObject.OnNewFrame(dt);        
        GL.PopMatrix();
        
        GL.PushMatrix();
        sprite.OnNewFrame(dt);
        GL.PopMatrix();       
    }
}
