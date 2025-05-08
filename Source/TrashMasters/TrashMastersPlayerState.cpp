// Copyright Kaime Welsh, all rights reserved.

#include "TrashMastersPlayerState.h"

ATrashMastersPlayerState::ATrashMastersPlayerState() {
	AbilitySystemComponent = CreateDefaultSubobject<UAbilitySystemComponent>(TEXT("AbilitySystemComponent"));
	AbilitySystemComponent->SetIsReplicated(true);
	AbilitySystemComponent->SetReplicationMode(EGameplayEffectReplicationMode::Full);
}

void ATrashMastersPlayerState::BeginPlay() {
	AbilitySystemComponent->InitStats(UAttributeSet::StaticClass(), nullptr);
}

UAbilitySystemComponent* ATrashMastersPlayerState::GetAbilitySystemComponent() const {
	return AbilitySystemComponent.Get();
}
