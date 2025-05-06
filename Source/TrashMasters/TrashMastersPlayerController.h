// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "TrashMastersPlayerController.generated.h"

class UInputMappingContext;
class UInputAction;
struct FInputActionInstance;

UCLASS()
class TRASHMASTERS_API ATrashMastersPlayerController : public APlayerController
{
	GENERATED_BODY()
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputMappingContext> InputMapping;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> MoveAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> LookAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> CrouchAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> JumpAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> SprintAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> InteractAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> PrimaryAction;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (AllowPrivateAccess = "true"))
	TSoftObjectPtr<UInputAction> SecondaryAction;

protected:
	void OnMove(const FInputActionInstance& Instance);
	void OnLook(const FInputActionInstance& Instance);
	void OnCrouch(const FInputActionInstance& Instance);
	void OnJump(const FInputActionInstance& Instance);
	void OnSprint(const FInputActionInstance& Instance);
	void OnInteract(const FInputActionInstance& Instance);
	void OnPrimary(const FInputActionInstance& Instance);
	void OnSecondary(const FInputActionInstance& Instance);

	virtual void SetupInputComponent() override;
	
};
