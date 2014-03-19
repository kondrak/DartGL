part of dart_gl;

/*
 * Enum type of application states
 */
class States
{
    static const int LOADING = 0;
    static const int INGAME  = 1;
}

/*
 * Application state abstraction
 */
abstract class GameState
{
    int _stateId;

    void OnEnter();
    void OnExit();
    void OnNewFrame(double dt);
    void onMouseMove(MouseEvent event);
    void onMouseDown(MouseEvent event);
    void onMouseUp(MouseEvent event);
    void onKeyDown(KeyboardEvent event);
    void onKeyUp(KeyboardEvent event);   
    void onFocus(Event event);
    void onBlur(Event event);
}


/*
 * FSM
 */
class FSM
{
    void SetState(int state)
    {
        if(currentState != null)
        {
            if(state == currentState._stateId)
                return;

            currentState.OnExit();
        }

        switch(state)
        {
        case States.LOADING:
            currentState = new LoadingState();
            break;
        case States.INGAME:
            currentState = new IngameState();
            break;
        }

        currentState.OnEnter();
    }

    void onMouseMove(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseMove(event);
    }

    void onMouseDown(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseDown(event);
    }

    void onMouseUp(MouseEvent event)
    {
        if(currentState != null)
            currentState.onMouseUp(event);
    }

    void onKeyDown(KeyboardEvent event)
    {
        if(currentState != null)
            currentState.onKeyDown(event);
    }

    void onKeyUp(KeyboardEvent event)
    {
        if(currentState != null)
            currentState.onKeyUp(event);
    }
    
    void onFocus(Event event)
    {
        if(currentState != null)
            currentState.onFocus(event);
    }
    
    void onBlur(Event event)
    {
        if(currentState != null)
            currentState.onBlur(event);
    }

    void OnNewFrame(double dt)
    {
        if(currentState != null)
            currentState.OnNewFrame(dt);
    }

    GameState currentState;
}


/*
 * Sample loading state
 */
class LoadingState implements GameState
{
    int _stateId = States.LOADING;

    void OnNewFrame(double dt)
    {
        // green background on resource loading
        glContext.clear(WebGL.RenderingContext.COLOR_BUFFER_BIT | WebGL.RenderingContext.DEPTH_BUFFER_BIT);
        glContext.clearColor(0.0, 1.0, 0.0, 1.0);

        // switch to INGAME state when finished loading
        if(soundMgr.allSoundsLoaded && texMgr.allTexLoaded)
            fsm.SetState(States.INGAME);
    }    
    
    void OnEnter()
    {

    }

    void OnExit()
    {

    }

    void onMouseMove(MouseEvent event)
    {

    }

    void onMouseDown(MouseEvent event)
    {

    }

    void onMouseUp(MouseEvent event)
    {

    }

    void onKeyDown(KeyboardEvent event)
    {

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
}
