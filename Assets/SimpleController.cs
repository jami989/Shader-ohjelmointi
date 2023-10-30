using UnityEngine;

[ExecuteAlways]
public class SimpleController : MonoBehaviour
{
    [SerializeField] private Material ProximityMaterial1;
    [SerializeField] private Material ProximityMaterial2;

    private static int PlayerPosID = Shader.PropertyToID("_PlayerPosition");
    
    private Vector3 movement;
    void Start()
    {
        
    }
    void Update()
    {
        movement = Vector3.zero;
        
        if (Input.GetKey(KeyCode.A))
            movement += Vector3.left;
        if (Input.GetKey(KeyCode.W))
            movement += Vector3.forward;
        if (Input.GetKey(KeyCode.D))
            movement += Vector3.right;
        if (Input.GetKey(KeyCode.S))
            movement += Vector3.back;
        
        transform.Translate(Time.deltaTime * 5 * movement.normalized, Space.World);
        
        ProximityMaterial1.SetVector(PlayerPosID, gameObject.transform.position);
        ProximityMaterial2.SetVector(PlayerPosID, gameObject.transform.position);
    }
}
