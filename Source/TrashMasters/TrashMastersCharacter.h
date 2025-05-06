// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "TrashMastersCharacter.generated.h"

struct FInputActionInstance;
class UInputMappingContext;
class UInputAction;

UCLASS()
class TRASHMASTERS_API ATrashMastersCharacter : public ACharacter {
	GENERATED_BODY()

public:
	// Sets default values for this character's properties
	ATrashMastersCharacter();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
	
public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;
	
	// Called by controller
	void Move(const FVector& Value);
	void Look(const FVector& Value);
	void Sprint();
	void StopSprinting();
	void Interact();
	void UsePrimary();
	void UseSecondary();
};
