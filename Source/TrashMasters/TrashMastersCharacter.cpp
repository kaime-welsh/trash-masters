// Fill out your copyright notice in the Description page of Project Settings.


#include "TrashMastersCharacter.h"

// Sets default values
ATrashMastersCharacter::ATrashMastersCharacter() {
	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}

// Called when the game starts or when spawned
void ATrashMastersCharacter::BeginPlay() { Super::BeginPlay(); }

void ATrashMastersCharacter::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) {
	Super::SetupPlayerInputComponent(PlayerInputComponent);
}

// Called every frame
void ATrashMastersCharacter::Tick(float DeltaTime) { Super::Tick(DeltaTime); }

void ATrashMastersCharacter::Move(const FVector& Value) {
	AddMovementInput(GetActorForwardVector(), Value.Y);
	AddMovementInput(GetActorRightVector(), Value.X);
}

void ATrashMastersCharacter::Look(const FVector& Value) {
	AddControllerYawInput(Value.X);
	AddControllerPitchInput(Value.Y);
}

void ATrashMastersCharacter::Sprint() {
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, "Sprinting");
}

void ATrashMastersCharacter::StopSprinting() {
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, "Not Sprinting");
}

void ATrashMastersCharacter::Interact() {
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, "Interacting");
}

void ATrashMastersCharacter::UsePrimary() {
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, "Using Primary");
}

void ATrashMastersCharacter::UseSecondary() {
	GEngine->AddOnScreenDebugMessage(-1, 5.f, FColor::Red, "Using Secondary");
}
