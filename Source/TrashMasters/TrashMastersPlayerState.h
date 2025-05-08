// Copyright Kaime Welsh, all rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemComponent.h"
#include "AbilitySystemInterface.h"
#include "GameFramework/PlayerState.h"
#include "TrashMastersPlayerState.generated.h"

UCLASS()
class TRASHMASTERS_API ATrashMastersPlayerState : public APlayerState, public IAbilitySystemInterface {
	GENERATED_BODY()

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "AbilitySystem", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

	ATrashMastersPlayerState();

protected:
	virtual void BeginPlay() override;
	
public:
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;
};
