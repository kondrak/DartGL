part of dart_gl;

/*
 * Camera controller helper class
 */
class CameraDirector
{
    List<Camera> cameras;
    Camera       activeCamera;
   
    CameraDirector()
    {
        cameras = new List<Camera>();
    }
  
    int AddCamera(Camera newCam)
    {
        cameras.add(newCam);
        activeCamera = cameras.last;
        
        return cameras.length-1;
    }
    
    void SetActiveCamera(int camNum)
    {
        activeCamera = cameras[camNum];
    }
  
    void ClearAll()
    {
       cameras.clear();
       activeCamera = null;
    }   
}


/*
 * Enum type
 */
class CameraMode
{
    static const int DOF6  = 0;  // DOF6 camera
    static const int FPS   = 1;  // standard FPS camera
    static const int ORTHO = 2;  // orthographic camera
}


/*
 * The camera
 */
class Camera
{ 
    // shader uniforms
    WebGL.UniformLocation u_pMatrixLocation;
    WebGL.UniformLocation u_mvMatrixLocation;

    Matrix4 modelViewMatrix;
    Matrix4 perspectiveMatrix;

    int     _mode;
    double  _yLimit;  // yaw limit for FPS camera
    double  _fov;
    double  _near;
    double  _far;
    double  _aspectRatio;
    double  _orthoScale;
    Vector3 _position;
    Vector3 _rotation;

    Vector3 _viewVector;
    Vector3 _rightVector;
    Vector3 _upVector;
  
    Move(Vector3 direction)      => _position = _position + direction;
    MoveForward(double distance) => _position = _position + (_viewVector * -distance);
    MoveUpward(double distance)  => _position = _position + (_upVector * distance);
    Strafe(double distance)      => _position = _position + (_rightVector * distance);    
  
    Camera(this._position, this._mode, double scrWidth, double scrHeight)
    {
        this._viewVector  = new Vector3(0.0, 0.0, -1.0);
        this._rightVector = new Vector3(1.0, 0.0, 0.0);
        this._upVector    = new Vector3(0.0, 1.0, 0.0);
        this._rotation    = new Vector3(0.0, 0.0, 0.0);
        this._yLimit = 1.0;
        
        this._fov  = 45.0;
        this._near = 0.1;
        this._far  = 100.0;
        this._aspectRatio = scrWidth / scrHeight;
        this._orthoScale = 1.0;
        
        if(_mode == CameraMode.ORTHO)
        {
            perspectiveMatrix  = makeOrthographicMatrix(-_aspectRatio * _orthoScale, 
                                                         _aspectRatio * _orthoScale, 
                                                        -1 * _orthoScale, 
                                                         1 * _orthoScale, 
                                                         _near, _far);            
        }
        else
        {
            perspectiveMatrix  = makePerspectiveMatrix(radians(_fov), _aspectRatio, _near, _far);
        }

        modelViewMatrix = makeViewMatrix(_position, _position + _viewVector, _upVector);
    }
      
    
    void SetMode(int camMode)
    {
      switch(camMode)
      {
        case CameraMode.ORTHO:
          perspectiveMatrix  = makeOrthographicMatrix(-_aspectRatio * _orthoScale, 
                                                       _aspectRatio * _orthoScale, 
                                                      -1 * _orthoScale, 
                                                       1 * _orthoScale, 
                                                       _near, _far);     
          break;
        case CameraMode.FPS:
        case CameraMode.DOF6:          
          perspectiveMatrix  = makePerspectiveMatrix(radians(_fov), _aspectRatio, _near, _far);
          break;                
      }
      
      _mode = camMode;
    }
    
    
    void applyTransformations() 
    {
        Float32List tmpList = new Float32List(16);

        perspectiveMatrix.copyIntoArray(tmpList);
        glContext.uniformMatrix4fv(u_pMatrixLocation, false, tmpList);

        modelViewMatrix.copyIntoArray(tmpList);
        glContext.uniformMatrix4fv(u_mvMatrixLocation, false, tmpList);
    }
    
    
    void RotateCamera(double angle, double x, double y, double z)
    {
        Quaternion result;

        // create quaternion from axis-angle
        Quaternion rotQuat  = new Quaternion.axisAngle(new Vector3(x, y, z), angle);
        Quaternion viewQuat = new Quaternion(_viewVector.x, _viewVector.y, _viewVector.z, 0.0);

        result = ((rotQuat * viewQuat) * rotQuat.conjugate());

        _viewVector.x = result.x;
        _viewVector.y = result.y;
        _viewVector.z = result.z;

        _rightVector = _viewVector.cross(_upVector);
        _rightVector = _rightVector.normalize();
    }

    
    void OnMouseMove(int dx, int dy)
    {
        Vector3 MouseDirection = new Vector3(0.0, 0.0, 0.0);

        // can't use movement property - not supported in javascript events (wat...)
        MouseDirection.x = dx / 800.0;
        MouseDirection.y = dy / 800.0;

        _rotation.x += MouseDirection.y;
        _rotation.y += MouseDirection.x;

        // camera up-down movement limit
        if (_mode == CameraMode.FPS)
        {
            if (_rotation.x > _yLimit)
            {
                MouseDirection.y = _yLimit + MouseDirection.y - _rotation.x;
                _rotation.x = _yLimit;
            }

            if (_rotation.x < -_yLimit)
            {
                MouseDirection.y = -_yLimit + MouseDirection.y - _rotation.x;
                _rotation.x = -_yLimit;
            }
        }

        //  x rotation axis.
        Vector3 Axis = _viewVector.cross(_upVector);
        
        // normalize to properly use the conjugate
        Axis = Axis.normalize();

        RotateCamera(-MouseDirection.y, Axis.x, Axis.y, Axis.z);

        if (_mode == CameraMode.DOF6)
        {
            _upVector = _rightVector.cross(_viewVector);
        }

        if (_mode == CameraMode.FPS)
        {
            RotateCamera(-MouseDirection.x, _upVector.x, _upVector.y, _upVector.z);
        }
        else
        {
            // Rotate in horizontal plane
            Vector3 Axis2 = _viewVector.cross(_rightVector);
            Axis2 = Axis2.normalize();

            RotateCamera(MouseDirection.x, Axis2.x, Axis2.y, Axis2.z);
        }

        _rightVector = _viewVector.cross(_upVector);
        _rightVector = _rightVector.normalize();
    }

    
    void OnNewFrame(double dt)
    {
        modelViewMatrix = makeViewMatrix(_position, _position + _viewVector, _upVector);      
        applyTransformations();  
    }
}