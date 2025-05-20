using Godot;
using System;

namespace TrashMasters.player
{
    [GlobalClass]
    public partial class FpsCharacter : RigidBody3D
    {
        [Export] public Node3D Head { get; set; }
        [Export] public Camera3D Camera { get; set; }

        [Export] private float _walkAcceleration = 5.0f;
        [Export] private float _sprintAcceleration = 8.5f;
        [Export] private float _jumpForce = 4.5f;

        private bool IsJumping { get; set; }
        private float MovementSpeed => Input.IsActionPressed("sprint") ? _sprintAcceleration : _walkAcceleration;

        private Vector3 _floorVelocity = Vector3.Zero;
        private float _airborneTime = float.PositiveInfinity;
        private float _mouseSensitivity = 0.006f;

        public override void _Ready()
        {
            base._Ready();
            Input.MouseMode = Input.MouseModeEnum.Captured;
        }

        public override void _UnhandledInput(InputEvent input)
        {
            base._UnhandledInput(input);

            if (input is InputEventMouseMotion mouseMotion && Input.MouseMode == Input.MouseModeEnum.Captured)
            {
                // Calculate rotation based on mouse movement
                var delta = mouseMotion.Relative;
                var yaw = -delta.X * _mouseSensitivity;
                var pitch = -delta.Y * _mouseSensitivity;

                Head.RotateY(yaw);
                Camera.RotateX(pitch);
                Camera.Rotation = new Vector3(
                    Mathf.Clamp(Camera.Rotation.X, Mathf.DegToRad(-89), Mathf.DegToRad(89)),
                    Camera.Rotation.Y,
                    Camera.Rotation.Z
                );
            }

            if (Input.IsActionJustPressed("ui_cancel"))
            {
                Input.MouseMode = Input.MouseModeEnum.Visible;
            }
        }

        public override void _Process(double delta)
        {
            base._Process(delta);
            if (Input.IsMouseButtonPressed(MouseButton.Left) && Input.MouseMode != Input.MouseModeEnum.Captured)
            {
                Input.MouseMode = Input.MouseModeEnum.Captured;
            }
        }

        public override void _IntegrateForces(PhysicsDirectBodyState3D state)
        {
            base._IntegrateForces(state);

            var velocity = Vector3.Zero;
            var inputDir = Input.GetVector("move_left", "move_right", "move_forward", "move_backward");
            velocity += Head.GlobalTransform.Basis.Z * inputDir.Y * MovementSpeed;
            velocity += Head.GlobalTransform.Basis.X * inputDir.X * MovementSpeed;
            velocity.Y = state.LinearVelocity.Y;

            if (Input.IsActionJustPressed("jump"))
            {
                velocity.Y = _jumpForce;
            }

            state.SetLinearVelocity(velocity);
        }
    }
}