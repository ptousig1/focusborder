
#include "focusborder.h"
#include "effect/effecthandler.h"

namespace KWin
	{
	FocusBorderEffect::FocusBorderEffect()
		{
		connect(effects, &EffectsHandler::windowActivated,
			this, &FocusBorderEffect::onActiveWindowChanged);
		}

	void FocusBorderEffect::onActiveWindowChanged(EffectWindow* w)
		{
		m_active = w;
		effects->addRepaintFull();
		}	

	void FocusBorderEffect::paintWindow(const RenderTarget &renderTarget,
										const RenderViewport &viewport,
										EffectWindow* w,
										int mask,
										QRegion region,
										WindowPaintData& data)
		{
		effects->paintWindow(renderTarget, viewport, w, mask, region, data);

		if (w == m_active)
			{
			// TODO: draw border here
			}
		}
	}
