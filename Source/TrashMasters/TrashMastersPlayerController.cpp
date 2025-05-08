// Copyright Kaime Welsh, all rights reserved.

#include "TrashMastersPlayerController.h"
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputMappingContext.h"
#include "TrashMastersCharacter.h"
#include "TrashMastersPlayerState.h"

void ATrashMastersPlayerController::BeginPlay() { Super::BeginPlay(); }

void ATrashMastersPlayerController::SetupInputComponent() {
	Super::SetupInputComponent();
	if (UEnhancedInputComponent* Input = Cast<UEnhancedInputComponent>(InputComponent))
	{
		const auto System = GetLocalPlayer()->GetSubsystem<UEnhancedInputLocalPlayerSubsystem>();
		System->AddMappingContext(InputMapping.LoadSynchronous(), 1);

		Input->BindAction(MoveAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnMove);
		Input->BindAction(LookAction.Get(), ETriggerEvent::Triggered, this, &ATrashMastersPlayerController::OnLook);
	}
}

UAbilitySystemComponent* ATrashMastersPlayerController::GetAbilitySystemComponent() const {
	const auto PS = GetPlayerState<ATrashMastersPlayerState>();
	return IsValid(PS) ? PS->GetAbilitySystemComponent() : nullptr;
}

void ATrashMastersPlayerController::TryInitializeGAS() {
	auto PlayerPawn = Cast<ATrashMastersCharacter>(GetPawn());
	if (IsValid(PlayerPawn))
	{
		GetAbilitySystemComponent()->RefreshAbilityActorInfo();
	}
}

void ATrashMastersPlayerController::OnPossess(APawn* InPawn) {
	Super::OnPossess(InPawn);
	TryInitializeGAS();
}

void ATrashMastersPlayerController::OnRep_PlayerState() {
	Super::OnRep_PlayerState();
	TryInitializeGAS();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///Input Functions
void ATrashMastersPlayerController::OnMove(const FInputActionInstance& Instance) {
	const FVector Value = Instance.GetValue().Get<FVector>();
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->Move(Value); }
}

void ATrashMastersPlayerController::OnLook(const FInputActionInstance& Instance) {
	const FVector Value = Instance.GetValue().Get<FVector>();
	if (const auto TrashCharacter = Cast<ATrashMastersCharacter>(GetPawn())) { TrashCharacter->Look(Value); }
}
