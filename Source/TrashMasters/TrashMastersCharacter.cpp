// Copyright Kaime Welsh, all rights reserved.

#include "TrashMastersCharacter.h"
#include "TrashMastersPlayerState.h"

ATrashMastersCharacter::ATrashMastersCharacter() { PrimaryActorTick.bCanEverTick = true; }

void ATrashMastersCharacter::BeginPlay() { Super::BeginPlay(); }

void ATrashMastersCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
	Super::SetupPlayerInputComponent(PlayerInputComponent);
}

void ATrashMastersCharacter::InitializeAbilityActorInfo() {
	if (ATrashMastersPlayerState* PS = Cast<ATrashMastersPlayerState>(GetPlayerState()))
	{
		if (UAbilitySystemComponent* AbilitySystemComponent = PS->GetAbilitySystemComponent())
		{
			AbilitySystemComponent->InitAbilityActorInfo(PS, this);
		}
	}
}

UAbilitySystemComponent* ATrashMastersCharacter::GetAbilitySystemComponent() const {
	if (const ATrashMastersPlayerState* PS = Cast<ATrashMastersPlayerState>(GetPlayerState()))
	{
		return PS->GetAbilitySystemComponent();
	}

	return nullptr;
}

void ATrashMastersCharacter::PossessedBy(AController* NewController) {
	Super::PossessedBy(NewController);
	InitializeAbilityActorInfo();
}

void ATrashMastersCharacter::OnRep_PlayerState() {
	Super::OnRep_PlayerState();
	InitializeAbilityActorInfo();
}

void ATrashMastersCharacter::Tick(float DeltaTime) { Super::Tick(DeltaTime); }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///Input Functions
void ATrashMastersCharacter::Move(const FVector& Value) {
	AddMovementInput(GetActorForwardVector(), Value.Y);
	AddMovementInput(GetActorRightVector(), Value.X);
}

void ATrashMastersCharacter::Look(const FVector& Value) {
	AddControllerYawInput(Value.X);
	AddControllerPitchInput(Value.Y);
}