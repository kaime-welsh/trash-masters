// Fill out your copyright notice in the Description page of Project Settings.


#include "TrashMastersPlayerController.h"
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputMappingContext.h"
#include "TrashMastersCharacter.h"

void ATrashMastersPlayerController::SetupInputComponent() {
	Super::SetupInputComponent();

	if (UEnhancedInputComponent* Input = Cast<UEnhancedInputComponent>(InputComponent))
	{
		auto System = GetLocalPlayer()->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>();
		System->AddMappingContext(InputMapping.LoadSynchronous(), 1);
		
		Input->BindAction(MoveAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnMove);
		Input->BindAction(LookAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnLook);
		Input->BindAction(CrouchAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnCrouch);
		Input->BindAction(JumpAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnJump);
		Input->BindAction(SprintAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnSprint);
		Input->BindAction(InteractAction.Get(),
		                  ETriggerEvent::Triggered,
		                  this,
		                  &ATrashMastersPlayerController::OnInteract);
	}
}

void ATrashMastersPlayerController::OnMove(const FInputActionInstance& Instance) {
	const FVector Value = Instance.GetValue().Get<FVector>();

	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->Move(Value); }
}

void ATrashMastersPlayerController::OnLook(const FInputActionInstance& Instance) {
	const FVector Value = Instance.GetValue().Get<FVector>();

	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->Look(Value); }
}

void ATrashMastersPlayerController::OnCrouch(const FInputActionInstance& Instance) {
	const bool Value = Instance.GetValue().Get<bool>();
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn()))
	{
		if (Value) { TrashCharacter->Crouch(); }
		else { TrashCharacter->UnCrouch(); }
	}
}

void ATrashMastersPlayerController::OnJump(const FInputActionInstance& Instance) {
	const bool Value = Instance.GetValue().Get<bool>();
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn()))
	{
		if (Value) { TrashCharacter->Jump(); }
		else { TrashCharacter->StopJumping(); }
	}
} 
void ATrashMastersPlayerController::OnSprint(const FInputActionInstance& Instance) {
	const bool Value = Instance.GetValue().Get<bool>();
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn()))
	{
		if (Value) { TrashCharacter->Sprint(); }
		else { TrashCharacter->StopSprinting(); }
	}
}

void ATrashMastersPlayerController::OnInteract(const FInputActionInstance& Instance) {
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->Interact(); }
}

void ATrashMastersPlayerController::OnPrimary(const FInputActionInstance& Instance) {
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->UsePrimary(); }
}

void ATrashMastersPlayerController::OnSecondary(const FInputActionInstance& Instance) {
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->UseSecondary(); }
}
