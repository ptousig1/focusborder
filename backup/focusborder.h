#pragma once

#include "effect/effect.h"

namespace KWin
	{
	class FocusBorderEffect : public Effect
		{
		Q_OBJECT

		public:
			FocusBorderEffect();
			~FocusBorderEffect() override = default;

			void paintWindow(const RenderTarget &renderTarget,
							const RenderViewport &viewport,
							EffectWindow* w,
							int mask,
							QRegion region,
							WindowPaintData& data) override;

		private:
			void onActiveWindowChanged(EffectWindow* w);

			EffectWindow* m_active = nullptr;
		};
	}

