// Copyright Kaime Welsh, all rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemInterface.h"
#include "GameFramework/Character.h"
#include "TrashMastersCharacter.generated.h"

struct FInputActionInstance;
class UInputMappingContext;
class UInputAction;

UCLASS()
class TRASHMASTERS_API ATrashMastersCharacter : public ACharacter, public IAbilitySystemInterface {
	GENERATED_BODY()

protected:
	virtual void BeginPlay() override;
	virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;
	
	void InitializeAbilityActorInfo();
	
public:
	ATrashMastersCharacter();
	
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;
	
	virtual void Tick(float DeltaTime) override;
	virtual void PossessedBy(AController* NewController) override;
	virtual void OnRep_PlayerState() override;
	
	void Move(const FVector& Value);
	void Look(const FVector& Value);
};