part of dart_gl;

/*
 * Sample ingame state - here be application processing
 */
class IngameState implements GameState
{
    int    _stateId = States.INGAME;
    Scene  _scene;
    bool   _mousePressed;
    int    _prevMouseX;
    int    _prevMouseY;
    Font   _font;
    
    void OnEnter()
    {
        this._mousePressed = false;
        this._prevMouseX = 0;
        this._prevMouseY = 0;

        camDirector.ClearAll();

        Camera camera = new Camera(new Vector3(0.25, -0.25, 2.0),
                                   CameraMode.FPS,
                                   double.parse(canvas.getAttribute("width")),
                                   double.parse(canvas.getAttribute("height")));

        camDirector.AddCamera(camera);

        _font = new Font(shaderMgr.Load('basicShader'), 'font', new Vector3(-5.5, 5.0, -1.0));
        _font.scale = new Vector3(2.0, 2.0, 1.0);
        _font.fixedPos = true;

        _scene = new Scene();

        _scene.Load();
    }

    void OnExit()
    {

    }

    void onMouseMove(MouseEvent event)
    {
        if(!_mousePressed)
            return;

        camDirector.activeCamera.OnMouseMove(event.client.x - _prevMouseX, event.client.y - _prevMouseY);

        _prevMouseX = event.client.x;
        _prevMouseY = event.client.y;

        event.preventDefault();
    }

    void onMouseDown(MouseEvent event)
    {
        if(!_mousePressed)
        {
            _prevMouseX = event.client.x;
            _prevMouseY = event.client.y;
        }

        _mousePressed = true;
    }

    void onMouseUp(MouseEvent event)
    {
        _mousePressed = false;
    }

    void onKeyDown(KeyboardEvent event)
    {
        // play music on key press
        if(event.keyCode == KeyCode.M)
            soundMgr.Toggle('example', false);        
    }

    void onKeyUp(KeyboardEvent event)
    {

    }
    
    void onFocus(Event event) 
    { 
        
    }
    
    void onBlur(Event event) 
    { 
        
    }    

    /*
     * Main state update loop
     */
    void OnNewFrame(double dt)
    {
        UpdateCamera(dt);

        GL.MatrixMode(MatrixModes.MODELVIEW);
        glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
        glContext.clearColor(0.0, 0.0, 0.0, 1.0);

        camDirector.activeCamera.OnNewFrame(dt);

        camDirector.activeCamera.SetMode(CameraMode.FPS);
        GL.PushMatrix();
        _scene.OnNewFrame(dt);
        GL.PopMatrix();

        camDirector.activeCamera.SetMode(CameraMode.ORTHO);
        GL.PushMatrix();
        _font.drawText("WASD to move, drag-and-move to look around, M to toggle sound!", new Vector4(1.0, 1.0, 1.0, 1.0));
        GL.PopMatrix();
        
        // important for yaw limit in FPS camera to work properly
        camDirector.activeCamera.SetMode(CameraMode.FPS);        
    }

    
    void UpdateCamera(double dt)
    {
        if(KeyCode.keyPressed[KeyCode.A] == true)
            camDirector.activeCamera.Strafe(-0.001 * dt);

        if(KeyCode.keyPressed[KeyCode.D] == true)
            camDirector.activeCamera.Strafe(0.001 * dt);

        if(KeyCode.keyPressed[KeyCode.S] == true)
            camDirector.activeCamera.MoveForward(0.001 * dt);

        if(KeyCode.keyPressed[KeyCode.W] == true)
            camDirector.activeCamera.MoveForward(-0.001 * dt);
    }
}