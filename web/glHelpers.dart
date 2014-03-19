part of dart_gl;

/*
 * Enum type for matrix mode
 */
class MatrixModes
{
    static const int MODELVIEW  = 1 << 0;
    static const int PROJECTION = 1 << 1;
}


/*
 * Matrix stack used by push/pop matrix
 */
class MatrixStack
{
    static int _matrixMode = MatrixModes.PROJECTION;
    static Queue<Matrix4> _modelViewStack  = new Queue();
    static Queue<Matrix4> _projectionStack = new Queue();

    static SetMode(int mode) => _matrixMode = mode;

    static void PushMatrix(Matrix4 matrix)
    {
        switch (_matrixMode)
        {
        case MatrixModes.MODELVIEW:
            _modelViewStack.addFirst(matrix.clone());
            break;
        case MatrixModes.PROJECTION:
            _projectionStack.addFirst(matrix.clone());
            break;
        }
    }

    static Matrix4 PopMatrix()
    {
        switch(_matrixMode)
        {
        case MatrixModes.MODELVIEW:
            if (_modelViewStack.length == 0)
            {
                throw new Exception("Invalid popMatrix!");
            }
            return _modelViewStack.removeFirst();
        case MatrixModes.PROJECTION:
            if (_projectionStack.length == 0)
            {
                throw new Exception("Invalid popMatrix!");
            }
            return _projectionStack.removeFirst();
        }
        
        return _modelViewStack.removeFirst();
    }
}


/*
 * OpenGL-ish functions
 */
class GL
{
    static void MatrixMode(int mode)
    {
        MatrixStack.SetMode(mode);
    }

    static void PushMatrix()
    {
        switch(MatrixStack._matrixMode)
        {
        case MatrixModes.MODELVIEW:
            MatrixStack.PushMatrix(camDirector.activeCamera.modelViewMatrix);
            break;
        case MatrixModes.PROJECTION:
            MatrixStack.PushMatrix(camDirector.activeCamera.perspectiveMatrix);
            break;
        }
    }

    static void PopMatrix()
    {
        switch(MatrixStack._matrixMode)
        {
        case MatrixModes.MODELVIEW:
            camDirector.activeCamera.modelViewMatrix = MatrixStack.PopMatrix();
            break;
        case MatrixModes.PROJECTION:
            camDirector.activeCamera.perspectiveMatrix = MatrixStack.PopMatrix();
            break;
        }
    }

    static void LoadIdentity()
    {
        switch(MatrixStack._matrixMode)
        {
        case MatrixModes.MODELVIEW:
            camDirector.activeCamera.modelViewMatrix = new Matrix4.identity();
            break;
        case MatrixModes.PROJECTION:
            camDirector.activeCamera.perspectiveMatrix = new Matrix4.identity();
            break;
        }

        camDirector.activeCamera.applyTransformations();
    }

    static void Scale(dynamic x, [double y = null, double z = null])
    {
        camDirector.activeCamera.modelViewMatrix.scale(x, y, z);
        camDirector.activeCamera.applyTransformations();
    }

    static void Translate(num x, num y, num z)
    {
        camDirector.activeCamera.modelViewMatrix.translate(x, y, z);
        camDirector.activeCamera.applyTransformations();
    }

    static void Translate3(Vector3 translation)
    {
        camDirector.activeCamera.modelViewMatrix.translate(translation.x, translation.y, translation.z);
        camDirector.activeCamera.applyTransformations();
    }

    static void Rotate(Vector3 axis, double angle)
    {
        camDirector.activeCamera.modelViewMatrix.rotate(axis, angle);
        camDirector.activeCamera.applyTransformations();
    }

    static void RotateXYZ(double rotX, double rotY, double rotZ)
    {
        camDirector.activeCamera.modelViewMatrix.rotateX(rotX);
        camDirector.activeCamera.modelViewMatrix.rotateY(rotY);
        camDirector.activeCamera.modelViewMatrix.rotateZ(rotZ);
        camDirector.activeCamera.applyTransformations();
    }

    static void RotateX(double angle)
    {
        camDirector.activeCamera.modelViewMatrix.rotateX(angle);
        camDirector.activeCamera.applyTransformations();
    }

    static void RotateY(double angle)
    {
        camDirector.activeCamera.modelViewMatrix.rotateY(angle);
        camDirector.activeCamera.applyTransformations();
    }

    static void RotateZ(double angle)
    {
        camDirector.activeCamera.modelViewMatrix.rotateZ(angle);
        camDirector.activeCamera.applyTransformations();
    }
    
    /*
     * Arbitrary vector rotation - just for the heck of it
     */
    static Vector2 RotateVector(Vector2 v, double angle, [Vector2 origin=null])
    {
        if(origin == null)
            origin = new Vector2(0.0, 0.0);
        
        v -= origin;
        
        double vx = v.x * Math.cos(angle) - v.y * Math.sin(angle);
        double vy = v.x * Math.sin(angle) + v.y * Math.cos(angle);
        
        return new Vector2(vx + origin.x, vy + origin.y);
    }
}

