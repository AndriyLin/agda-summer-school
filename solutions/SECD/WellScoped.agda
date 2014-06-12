
module SECD.WellScoped where

open import Prelude
open import Data.List

open import Term
open import Term.Show
open Term.WellScoped

data Value : Set

Cxt = List Name

Env : Cxt → Set
Env Γ = All (const Value) Γ

data Value where
  lit     : Nat → Value
  suc     : Value
  closure : ∀ {Γ} (x : Name) → Env Γ → Term (x ∷ Γ) → Value

data Directive Γ : Set where
  term  : Term Γ → Directive Γ
  apply : Directive Γ

Stack   = List Value
Control = λ Γ → List (Directive Γ)

record Snapshot : Set where
  constructor snapshot
  field
    stack       : Stack
    {Γ}         : Cxt
    environment : Env Γ
    control     : Control Γ

Dump = List Snapshot

record SECD : Set where
  constructor secd
  field
    current : Snapshot
    dump    : Dump

  open Snapshot current public

infix 1 _∣_∣_∣_
pattern _∣_∣_∣_ s e c d = secd (snapshot s e c) d

data StepResult : Set where
  done  : Value → StepResult
  next  : SECD → StepResult
  error : String → StepResult

step : SECD → StepResult

step (v ∷ [] ∣ _ ∣ [] ∣ []) = done v

step (v ∷ [] ∣ e′ ∣ [] ∣ (snapshot s e c) ∷ d) =
  next (v ∷ s ∣ e ∣ c ∣ d)

step (s ∣ e ∣ term (lit n) ∷ c ∣ d) =
  next (lit n ∷ s ∣ e ∣ c ∣ d)

step (s ∣ e ∣ term (var x i) ∷ c ∣ d) =
  next (lookup∈ e i ∷ s ∣ e ∣ c ∣ d)

step (s ∣ e ∣ term suc ∷ c ∣ d) =
  next (suc ∷ s ∣ e ∣ c ∣ d)

step (s ∣ e ∣ term (lam x a t) ∷ c ∣ d) =
  next (closure x e t ∷ s ∣ e ∣ c ∣ d)

step (s ∣ e ∣ term (app t₁ t₂) ∷ c ∣ d) =
  next (s ∣ e ∣ term t₂ ∷ term t₁ ∷ apply ∷ c ∣ d)

step (suc ∷ lit n ∷ s ∣ e ∣ apply ∷ c ∣ d) =
  next (lit (suc n) ∷ s ∣ e ∣ c ∣ d)

step (closure x e′ t ∷ v ∷ s ∣ e ∣ apply ∷ c ∣ d) =
  next ([] ∣ v ∷ e′ ∣ term t ∷ [] ∣ (snapshot s e c) ∷ d)

step ([]                      ∣ _ ∣ []        ∣ _) = error "empty stack on return"
step (_ ∷ _ ∷ _               ∣ _ ∣ []        ∣ _) = error "more than one stack element on return"
step ([]                      ∣ _ ∣ apply ∷ _ ∣ _) = error "apply on empty stack"
step (_ ∷ []                  ∣ _ ∣ apply ∷ _ ∣ _) = error "apply on singleton stack"
step (lit _ ∷ _ ∷ _           ∣ _ ∣ apply ∷ _ ∣ _) = error "apply literal"
step (suc ∷ suc ∷ _           ∣ _ ∣ apply ∷ _ ∣ _) = error "apply suc to suc"
step (suc ∷ closure _ _ _ ∷ _ ∣ _ ∣ apply ∷ _ ∣ _) = error "apply suc to closure"

{-# NO_TERMINATION_CHECK #-}
run′ : SECD → Either String Value
run′ s with step s
... | next s′ = run′ s′
... | done v  = right v
... | error e = left e 

run : Term [] → Either String Value
run t = run′ ([] ∣ [] ∣ term t ∷ [] ∣ [])

-- Show instance for values --

private
  showValue : Nat → Value → ShowS
  showEnv   : ∀ {Γ} → Env Γ → ShowS

  showValue p (lit n)         = shows n
  showValue p suc             = showString "suc"
  showValue p (closure x e v) = showParen (p > 0) $ showEnv e ∘ showString (" λ " & x & " → ") ∘ shows v

  showBinding : Name × Value → ShowS
  showBinding (x , v) = showString x ∘ showString " = " ∘ showValue 0 v

  showEnv′ : ∀ {Γ} → Env Γ → ShowS
  showEnv′ []       = showString ""
  showEnv′ {Γ = x ∷ []} (v ∷ []) = showBinding (x , v)
  showEnv′ {Γ = x ∷ Γ } (v ∷ e)  = showBinding (x , v) ∘ showString ", " ∘ showEnv′ e

  showEnv e = showString "[" ∘ showEnv′ e ∘ showString "]"

ShowValue : Show Value
ShowValue = record { showsPrec = showValue }